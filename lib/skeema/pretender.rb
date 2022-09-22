module ActiveRecord
  class Schema
    def create_table(table_name, options={}, &block)
      table = Table.new(table_name)
      yield table if block_given?
      self.class.add_table(table.name, table.columns)
    end

    def method_missing(*args)
      # ignore add_index, etc.
    end

    def self.define(*args, &block)
      new.instance_eval(&block)
    end

    def self.add_table(table_name, columns)
      @schema ||= {}
      @schema[table_name] = columns
    end

    def self.schema
      @schema || {}
    end
  end

  class Table
    attr_reader :name, :columns

    def initialize(name)
      @name = name
      @columns = []
    end

    def method_missing(data_type, *column_names_and_options)
      @columns += if column_names_and_options.last.is_a?(Hash)
        [[column_names_and_options.first, column_names_and_options.last.merge(data_type: data_type)]]
      else
        [column_names_and_options << {data_type: data_type}]
      end
    end
  end
end

module Skeema
  class Pretender
    def self.parse(filename)
      require filename

      ActiveRecord::Schema.schema
    end
  end
end
