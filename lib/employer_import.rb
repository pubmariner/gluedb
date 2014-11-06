require "net/http"

class EmployerImport
  ENDPOINT = "http://localhost:3000"
  PATH = "/employers"

  def initialize(endpoint = ENDPOINT, path = PATH)
    uri = URI.parse(endpoint)
    @http = Net::HTTP.new(uri.host, uri.port)
    @path = path
  end

  def new_employers(file)
  end

  def existing_employers
    Employer.all.in_groups_of(5, false) do |employers|
      fetch_employer_group(employers.map(&:fein))
      break
    end
  end

  def fetch_employer_group(feins)
    begin
      response = request :get, @path, {'feins' => feins.join(',')}
      validate_n_process(response)
    rescue
    end  
  end

  def validate_n_process(response)
    case response.code.to_i
    when 200 || 201
      ImportEmployerDemographics.execute(response.body)
    when (400..499)
      raise 'Bad Request'
    when (500..599)
      raise 'Server Issues'
    end
  end

  private

  def request(method, path, params = {})
    full_path = encode_path_params(path, params)
    puts full_path.inspect
    request = Net::HTTP::Get.new(full_path)

    @http.request(request)
  end

  def encode_path_params(path, params)
    encoded = URI.encode_www_form(params)
    [path, encoded].join("?")
  end
end