class Recipe < ActiveRecord::Base
  has_many :materials
  has_many :ingredients, through: :materials
  has_many :labels
  has_many :tags, through: :labels

  def associate_tag(tag_arr)
    self.labels.each() do |label|
      label.destroy()
    end
    if tag_arr!=nil
      tag_arr.each do |tag_id|
        found_tag = Tag.find(tag_id.to_i)
        self.tags.push(found_tag)
      end
    end
  end

  def tag_ids
    id_arr = []
    self.tags.each do |tag|
      id_arr.push(tag.id)
    end
    id_arr
  end

end
