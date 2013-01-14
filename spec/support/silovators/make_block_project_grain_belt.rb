class MakeBlockProjectGrainBelt < MongoidSilo::GrainBelt
  def generate
    {
      name: name,
      items: item_array
    }
  end

  def item_array
    block_project_items.each_with_object([]) do |itm, arr|
      arr << {
        name: itm.name
      }
    end
  end
end