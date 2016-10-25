# Query total funcional ejecutado

year = 2015
place = INE::Places::Place.find 43057

# Import economic sublevels
sql = <<-SQL
SELECT *
FROM tb_funcional_#{year}
INNER JOIN "tb_inventario_#{year}" ON tb_inventario_#{year}.idente = tb_funcional_#{year}.idente AND tb_inventario_#{year}.codente = '#{format("%.5i", place.id)}AA000'
GROUP BY cdfgr
SQL

puts sql

# Gasto funcional ejecutado madrid 2014
# SELECT sum(tb_funcional_2014.importe) as amount
# FROM tb_funcional_2014
# INNER JOIN "tb_inventario_2014" ON tb_inventario_2014.idente = tb_funcional_2014.idente AND tb_inventario_2014.codente = '28079AA000'
# WHERE length(tb_funcional_2014.cdfgr) = 1;
# 5_697_516_966.50

amount_column = 'importer'
sql = <<-SQL
SELECT tb_economica_#{year}.cdcta as code, tb_economica_#{year}.tipreig AS kind, tb_economica_#{year}.#{amount_column} as amount
FROM tb_economica_#{year}
INNER JOIN "tb_inventario_#{year}" ON tb_inventario_#{year}.idente = tb_economica_#{year}.idente AND tb_inventario_#{year}.codente = '#{format("%.5i", place.id)}AA000'
WHERE length(code)=1 AND kind='I'
SQL

# 5_906_427_182.81
#
#
# 208_910_216.31


real_debt2013 = 7_035_765_000
real_debt2014 = 5_938_001_000

debt_reduction = 1_097_764_000

debt_payment_2014=2_344_000_000

estimated_debt_2014 = real_debt2013 - debt_payment_2014
# 4691765000
real_debt2014 - estimated_debt_2014
# 1_246_236_000
