require "httparty"

class StneographyService
  include HTTParty
  base_uri "https://stenography-production.up.railway.app/" # Replace with your actual API URL

  # Endpoint 1: /process
  def self.process(text, image)
    options ={
      body: {
        image: image,
        text: text
      }
    }

    response = post("/process", options)

  response
  end

  # Endpoint 2: /reverse
  def self.reverse(image, original_image)
    options = {
      body: {
        imageOu: image,
        imageOg: original_image
      }
    }

    response = post("/reverse", options)
    response
  end

  # Endpoint 3: /task_status
  def self.task_status(taskid)
    response = get("/task_status/#{taskid}")

    response
  end
end
