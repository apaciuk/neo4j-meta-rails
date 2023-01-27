

class Asset 
    include Neo4j::ActiveNode
    include Neo4j::Paperclip 
    
    include Authorizable 
    include QueryAuthorizer

    property :title 
    has_neo4jrb_attached_file :image 
    validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/ 
    property :view_count, type: Integer, default: 0
    property :private, type: Boolean, default: false
    has_many :out, categories, type: :HAS_CATEGORY, model_class: :Category
    has_many :in, :creators, type: :CREATED, model_class: :User
    has_many :in, :viewers, rel_class: :View, model_class: :User

    SecretSauceRecommendation = Struct.new(:asset, :score) 

    def secret_sauce_recommendations
        query_as(:source) 
            .match("source-[:CREATED]->(asset:Asset)") 
            .where("asset.uuid <> {uuid}") 
            .with("asset, count(asset) as score") 
            .order("score DESC") 
            .limit(5) 
            .pluck(
             :asset,
             '(count(category) * 2) +
                (count(creator) * 3) +
                (count(viewer) * 1) AS score'
            ) 
            .map { |other_asset, score| SecretSauceRecommendation.new(other_asset, score) } 
    end
    
end