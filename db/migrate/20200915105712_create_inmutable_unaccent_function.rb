# frozen_string_literal: true

class CreateInmutableUnaccentFunction < ActiveRecord::Migration[6.0]
  def up
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.immutable_unaccent(regdictionary, text)
        RETURNS text LANGUAGE c IMMUTABLE STRICT AS
      '$libdir/unaccent', 'unaccent_dict';

      CREATE OR REPLACE FUNCTION public.f_unaccent(text)
        RETURNS text LANGUAGE sql IMMUTABLE STRICT AS
      $func$
      SELECT public.immutable_unaccent(regdictionary 'public.unaccent', $1)
      $func$;
    SQL
  end

  def down
    execute <<-SQL
      DROP FUNCTION IF EXISTS public.f_unaccent(text);

      DROP FUNCTION IF EXISTS public.immutable_unaccent(regdictionary, text);
    SQL
  end
end
