class SlaPolicyDrop < BaseDrop
  def description
    @obj.try(:description)
  end
end
