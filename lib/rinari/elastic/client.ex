defmodule Rinari.Elastic.Client do
  @max_entries 10000

  def search(%Rinari.Request.PageRequest{}, _schema, offset, limit) when (offset + limit) > @max_entries, do: []

  def search(%Rinari.Request.PageRequest{genre: genre, keywords: keywords, sort: sort, order: order}, schema, offset, limit) do
    bool_query = %{}

    bool_query = if keywords do
      terms = %{"should" =>
                 %{"match_phrase_prefix" => %{"title" => keywords},
                   "term" => %{"imdb_id" => keywords},
                   "minimum_should_match" => 1
                  }
                }

      MapUtils.deep_merge(bool_query, terms)
    else
      bool_query
    end

    bool_query = if genre do
      MapUtils.deep_merge(bool_query, %{"must" => %{"term" => %{"genre" => genre}}})
    else
      bool_query
    end

    bool_query = if bool_query == %{} do
      %{"match_all" => %{}}
    else
      %{"bool" => bool_query}
    end

    query = %{
      "query" => bool_query,
      "from" => offset,
      "size" => limit
    }

    target = schema.__schema__(:source)

    path = "/#{target}/_doc/_search"
    IO.inspect({path, query})

    Elasticsearch.post(Rinari.Elastic.Cluster, path, query)
  end

  def put(entity) do
    target = entity.__meta__.schema.__schema__(:source)
    Elasticsearch.put_document(Rinari.Elastic.Cluster, entity, target)
  end
 end
