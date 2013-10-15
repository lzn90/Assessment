require 'multi_json'
require 'rest-client'
require 'uri-handler'

class CouchDB

    def initialize(url)
        @url = url
    end

    def _get(url="")
        r = RestClient.get "#{@url}#{url}"
        MultiJson.load(r.to_str, :symbolize_keys => true)
    end

    def _post(data)
        r = RestClient.post "#{@url}", MultiJson.dump(data), :content_type => :json, :accept => :json
        MultiJson.load(r.to_str, :symbolize_keys => true)
    end

    def db()
        _get()
    end

    def create(doc)
        r = _post(doc)
        doc[:_id]  = r[:id]
        doc[:_rev] = r[:rev]
        doc
    end

    def update(doc)
        r = _post(doc)
        doc[:_rev] = r[:rev]
        doc
    end

    def get(id)
        begin
            _get "/#{id}"
        rescue RestClient::ResourceNotFound
            nil
        end
    end

    def delete(doc)
        r = RestClient.delete "#{@url}/#{doc[:_id]}?rev=#{doc[:_rev]}", :content_type => :json
        nil
    end

    def view(design,view,args={})
        url = "/_design/#{design}/_view/#{view}?"
        if args.has_key?(:key)
            key = MultiJson.dump(args[:key]).to_uri
            url << "&key=#{key}"
        end
        _get(url)[:rows]
    end

    def get_all() 
        docs = []
        _get("/_all_docs?_include_docs=true")[:rows].each{ | row | docs << row[:doc ] }
        docs
    end
end
