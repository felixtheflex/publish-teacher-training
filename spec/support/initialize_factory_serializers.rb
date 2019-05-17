FactoryBot.factories.each do |factory|
  next if factory.name == :error

  model_class_name      = factory.name.to_s.camelize
  model_class           = model_class_name.constantize
  # Create a string that holds the name of the class, for example
  # "UserSerializer"
  serializer_class_name = "#{model_class_name}Serializer"

  # Create a new class (of type Class) and make it inherit from the JSONAPI
  # serializer resource. Everything in the block is related to the serializer.
  serializer_class = Class.new(JSONAPI::Serializable::Resource) do
    # Set the serializer type to the plural of the factory name, for example
    # "users".
    type(factory.name.to_s.pluralize)

    # Set the attributes to render out to the attributes we define in the
    # factory. The ID is omitted.
    attributes(*FactoryBot.attributes_for(factory.name).keys.reject { |attribute| attribute == :id })

    # Setup associations
    model_class.associations.each do |association|
      self.send(
        # This figures out if it's a belongs_to, has_many, etc.
        association.class.to_s.chomp('::Association').demodulize.underscore,
        # This sets the name of the assoication, for example :users
        association.attr_name
      )
    end
  end

  # Create a new constant with the class name and make it point to the class
  # we created. For example "UserSerializer", and it would point to the class
  # we created.
  Object.const_set(serializer_class_name, serializer_class)

  # Build a hash to map model classes to serializer classes. For example:
  # User: UserSerializer
  # This is used by the renderer to know how to render classes.
  SerializerMap.models_to_serializers ||= {}
  SerializerMap.models_to_serializers[model_class_name.to_sym] = serializer_class
end
