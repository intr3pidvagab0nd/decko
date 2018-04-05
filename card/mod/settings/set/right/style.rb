require "sass"
include_set Abstract::Machine

store_machine_output filetype: "css"

format do
  def chunk_list  # turn off autodetection of uri's
    :nest_only
  end
end

format :html do
  view :editor, template: :haml

  def themes
    Card.search type_id: SkinID
  end
end

event :customize_theme, :prepare_to_validate, on: :update, when: :customize_theme? do
  skin_name = free_skin_name
  add_subcard skin_name, type_id: CustomizedSkinID
  self.content = "[[#{skin_name}]]"
end

def free_skin_name
  name = "#{@theme} skin customized"
  if Card.exist?(name)
    name = "#{name} 1"
    while Card.exist?(name) do
      name.next!
    end
  end
  name
end

def customize_theme?
  Env.params[:customize].present? && (@theme = Env.params[:theme]).present?
end
