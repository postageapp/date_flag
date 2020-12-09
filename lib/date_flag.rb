require 'set'

module DateFlag
  VERSION = File.read(File.expand_path('../VERSION', File.dirname(__FILE__))).chomp

  # Usage:
  #
  # class MyModel < ActiveRecord::Base
  #   date_flag :flagged_at, action: :flag
  # end
  #
  # m = MyModel.new
  # m.flagged?     # => false
  # m.flag!        # Assigns flag_at to current time
  # m.flag = true  # Same as flag!
  # m.flagged?     # => true

  def date_flag(field, options =  { })
    unless (defined?(@date_flags))
      @date_flags = Set.new
    end

    name = (options[:name] ? options[:name] : field.to_s.sub(/_at$/, '')).to_sym
    action = (options[:action] ? options[:action] : name).to_sym

    @date_flags << name
    @date_flags << :"#{name}_at"

    scope_name =
      case (options[:scope])
      when nil, true
        name
      when false
        false
      else
        options[:scope].to_s.to_sym
      end

    case (scope_name)
    when false, nil
      # Skip this operation
    when :send, :id
      # TODO: Invalid names, should raise exception or warning
    else
      scope scope_name, lambda { |*flag|
        case (flag.first)
        when false
          where(field => nil)
        when true, nil
          where.not(field => nil)
        else
          # FIX: Escape properly for Postgres/MySQL
          where([ "#{field}<=?", flag.first ])
        end
      }
    end

    if (options[:inverse])
      scope options[:inverse], lambda { |*flag|
        case (flag.first)
        when false
          where.not(field => nil)
        when true, nil
          where(field => nil)
        else
          # FIX: Escape properly for Postgres/MySQL
          where([ "#{field}>?", flag.first ])
        end
      }
    end

    if (inverse_action = options[:inverse_action] || options[:inverse])
      define_method(:"#{inverse_action}!") do
        write_attribute(field, nil)

        save!
      end
    end

    define_method(:"#{name}=") do |value|
      # The action= mutator method is used to manipulate the trigger time.
      # Values of nil, false, empty string, '0' or 0 are presumed to be
      # false and will nil out the time. A DateTime, Date or Time object
      # will be saved as-is, and anything else will just assign the current
      # time.

      case (value)
      when nil, false, '', '0', 0
        write_attribute(field, nil)
      when DateTime, Date, Time
        write_attribute(field, value)
      else
        !read_attribute(field) and write_attribute(field, Time.now)
      end
    end

    define_method(:"#{name}") do
      value = read_attribute(field)

      value ? (value <= Time.now) : false
    end

    define_method(:"#{name}?") do
      # The name? accessor method will return true if the date is defined
      # and is prior to the current time, or false otherwise.
      value = read_attribute(field)

      value ? (value <= Time.now) : false
    end

    define_method(:"#{action}!") do |*at_time|
      # The name! method is used to set the trigger time. If the time is
      # already defined and is in the past, then the time is left unchanged.
      # If it is undefined or in the future, then the current time is
      # substituted.

      value = read_attribute(field)

      at_time =
        case (at_time.first)
        when false
          nil
        else
          at_time.first || value || Time.now
        end

      return if (at_time == value)

      write_attribute(field, at_time)
      save!
    end
  end

  def date_flag?(name)
    name and @date_flags.include?(name.to_sym)
  end
end

if (defined?(ActiveRecord))
  ActiveRecord::Base.extend(DateFlag)
end
