class LinearRegression
  def initialize(x, y)
    n = y.length
    sum_x = 0
    sum_y = 0
    sum_xy = 0
    sum_xx = 0
    sum_yy = 0

    i = 0
    while (i < y.length) do
      sum_x += x[i].to_f
      sum_y += y[i].to_f
      sum_xy += (x[i].to_f*y[i].to_f)
      sum_xx += (x[i].to_f*x[i].to_f)
      sum_yy += (y[i].to_f*y[i].to_f)
      i+=1
    end

    @slope = (n * sum_xy - sum_x * sum_y) / (n*sum_xx - sum_x * sum_x)
    @intercept = (sum_y - @slope * sum_x)/n
  end

  def fn(x)
    @slope * x + @intercept
  end
end

CSV.open("debt-projected-closed.csv", "wb") do |csv|
  csv << %W{ year ine_code }

  data = {}

  (2010..2015).each do |year|
    file_path = Rails.root.join 'db', 'data', 'debt', "debt-#{year}.csv"
    unless File.file?(file_path)
      raise "Missing file #{file_path}"
    end

    data[year] = Hash[CSV.read(file_path).map do |r|
      id = r[1] + format('%.3i', r[2].to_i)
      [id, r[4].to_f]
    end]
  end

  INE::Places::Place.all.each do |place|
    x = [2013, 2014, 2015]
    y = x.map do |year|
      data[year][place.id]
    end
    next if y.any?{|e| e.nil? }
    next if y.last == 0

    lr = LinearRegression.new x, y
    (2016..2066).each do |projected_year|
      projected_debt = lr.fn(projected_year)
      if projected_debt < 0
        csv << [projected_year, place.id]
        break
      end
    end
  end
end

