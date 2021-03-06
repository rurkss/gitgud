defmodule GitGud.GraphQL.Types do
  @moduledoc """
  GraphQL types for `GitGud.GraphQL.Schema`.
  """

  use Absinthe.Schema.Notation
  use Absinthe.Relay.Schema.Notation, :modern

  alias GitRekt.Git
  alias GitGud.GraphQL.Resolvers

  scalar :git_oid, name: "GitObjectID" do
    serialize &Git.oid_fmt/1
    parse &Git.oid_parse/1
  end

  enum :git_reference_type do
    value :branch
    value :tag
  end

  node object :user do
    field :username, non_null(:string)
    field :name, :string
    field :email, non_null(:string)
    field :repos, non_null(list_of(:repo)), resolve: &Resolvers.user_repos/3
    field :repo, :repo do
      arg :name, non_null(:string)
      resolve &Resolvers.user_repo/3
    end
    field :url, non_null(:string), resolve: &Resolvers.url/3
  end

  node object :repo do
    field :name, non_null(:string)
    field :description, :string
    field :owner, non_null(:user), resolve: &Resolvers.repo_owner/3
    field :head, :git_reference, resolve: &Resolvers.repo_head/3
    field :object, :git_object do
      arg :rev, non_null(:string)
      resolve &Resolvers.git_object/3
    end

    field :refs, non_null(list_of(:git_reference)) do
      arg :glob, :string
      resolve &Resolvers.repo_refs/3
    end

    field :ref, :git_reference do
      arg :shorthand, :string
      arg :name, :string
      resolve &Resolvers.repo_ref/3
    end
    field :url, non_null(:string), resolve: &Resolvers.url/3
  end

  object :git_reference do
    field :oid, non_null(:git_oid)
    field :name, non_null(:string)
    field :shorthand, non_null(:string)
    field :object, non_null(:git_object), resolve: &Resolvers.git_object/3
    field :repo, non_null(:repo)
    field :url, non_null(:string), resolve: &Resolvers.url/3
    field :type, non_null(:git_reference_type), resolve: &Resolvers.git_reference_type/3
  end

  interface :git_object do
    field :oid, non_null(:git_oid)
    field :repo, non_null(:repo)
    resolve_type &Resolvers.git_object_type/2
  end

  object :git_commit do
    interface :git_object
    field :oid, non_null(:git_oid)
    field :author, non_null(:user), resolve: &Resolvers.git_commit_author/3
    field :message, non_null(:string), resolve: &Resolvers.git_commit_message/3
    field :tree, non_null(:git_tree), resolve: &Resolvers.git_commit_tree/3
    field :repo, non_null(:repo)
  end

  object :git_tree do
    interface :git_object
    field :oid, non_null(:git_oid)
    field :count, non_null(:integer), resolve: &Resolvers.git_tree_count/3
    field :entries, non_null(list_of(:git_tree_entry)), resolve: &Resolvers.git_tree_entries/3
    field :repo, non_null(:repo)
  end

  object :git_tree_entry do
    field :name, non_null(:string)
    field :type, non_null(:string)
    field :mode, non_null(:integer)
    field :object, non_null(:git_object), resolve: &Resolvers.git_object/3
    field :repo, non_null(:repo)
  end

  object :git_blob do
    interface :git_object
    field :oid, non_null(:git_oid)
    field :size, non_null(:integer), resolve: &Resolvers.git_blob_size/3
    field :repo, non_null(:repo)
  end
end
