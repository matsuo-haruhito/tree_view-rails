# frozen_string_literal: true

module Theme::Bootstrap4Helper
  def collection_select(*args)
    set_default_classes(args, 6, %w[form-control])
    super
  end

  def date_field(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def datetime_field(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def number_field(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def password_field(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def search_field(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def text_area(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def text_field(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def text_field_tag(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def select(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def select_tag(*args)
    set_default_classes(args, 2, %w[form-control])
    super
  end

  def submit_tag(*args)
    set_default_classes(args, 1, %w[btn btn-primary])
    super
  end

  def set_default_classes(args, index, classes)
    args[index] ||= {}
    options = args[index]
    unless options.has_key? :class
      options[:class] = Array.wrap(options[:class])
      options[:class].prepend(*classes).uniq!
    end
  end
end
