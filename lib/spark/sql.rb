module Spark
  module SQL
    autoload :Column,          'spark/sql/column'
    autoload :Context,         'spark/sql/context'
    autoload :DataFrame,       'spark/sql/data_frame'
    autoload :DataFrameReader, 'spark/sql/data_frame_reader'
  end

  SQLContext = Spark::SQL::Context
end