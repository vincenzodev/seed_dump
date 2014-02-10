class SeedDump
  module Environment

    def dump_using_environment(env = {})
      Rails.application.eager_load!

      models = if env['MODEL'] || env['MODELS']
                 (env['MODEL'] || env['MODELS']).split(',').collect {|x| x.strip.underscore.singularize.camelize.constantize }
               else
                 ActiveRecord::Base.descendants.select do |model|
                   (model.to_s != 'ActiveRecord::SchemaMigration') && \
                    model.table_exists? && \
                    model.exists? && \
                    model.superclass == ActiveRecord::Base
                 end
               end

      append = (env['APPEND'] == 'true')

      models.each do |model|
        model = model.limit(env['LIMIT'].to_i) if env['LIMIT']

        SeedDump.dump(model,
                      without_protection: ((env['WITHOUT_PROTECTION'] =~ /(true|t|yes|y|1)$/i) == 0),
                      append: append,
                      batch_size: (env['BATCH_SIZE'] ? env['BATCH_SIZE'].to_i : nil),
                      exclude: (env['EXCLUDE'] ? env['EXCLUDE'].split(',').map {|e| e.strip.to_sym} : nil),
                      file: (env['FILE'] || 'db/seeds_backups.rb'))

        append = true
      end
    end
  end
end

