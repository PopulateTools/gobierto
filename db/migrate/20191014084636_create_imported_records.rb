# frozen_string_literal: true

class CreateImportedRecords < ActiveRecord::Migration[5.2]
  def change
    ###############
    # mercamadrid #
    ###############

    create_table :imported_records do |t|
      t.date :start_date
      t.date :end_date
      t.string :variety_code
      t.string :variety_description
      t.string :origin
      t.string :origin_description
      t.integer :kilograms
      t.decimal :expected_price
      t.decimal :maximum_price
      t.decimal :minimum_price
      t.string :family
      t.boolean :national
      t.string :category
      t.string :product_name
    end

    ##################
    # taxi_flota_mad #
    ##################

    # create_table :imported_records do |t|
    #   t.integer :codigo
    #   t.string :matricula
    #   t.date :fecha_matriculacion
    #   t.string :marca
    #   t.string :modelo
    #   t.string :tipo
    #   t.string :variante
    #   t.string :clasificacion_medioambiental
    #   t.string :combustible
    #   t.integer :cilindrada
    #   t.decimal :potencia
    #   t.string :numero_de_plazas
    #   t.date :fecha_inicio_de_prestacion_del_servicio_de_taxi
    #   t.boolean :eurotaxi
    #   t.boolean :regimen_especial_de_eurotaxi
    #   t.date :fecha_inicio_regimen_especial_eurotaxi
    #   t.date :fecha_fin_regimen_especial_eurotaxi
    #   t.date :fecha
    #   t.integer :ano_matriculacion
    #   t.string :ano_mes_matriculacion
    # end
  end
end
