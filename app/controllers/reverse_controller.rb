class ReverseController < ApplicationController
    def decrypt
      render "reverse/decryption"

      text = params[:text]
      if text.nil?
          flash[:alert] = "text extraction failed try again"
      else
        @text = text
      end
    end

    def stneography_reverse
      imageOg = params[:imageOg]
      imageOu = params[:imageOu]

      # Ensure both files are provided
      if imageOg.nil? || imageOu.nil?
        flash[:alert] = "Both original and output images are required."
        redirect_to root_path
        return
      end

      begin
        # Call the reverse service and retrieve the task ID
        response = StneographyService.reverse(imageOg, imageOu)

        if response["taskid"].present?
          @task_id = response["taskid"]
          redirect_to message_path(task_id: @task_id, filesize: File.size(imageOg))
        else
          flash[:alert] = "Failed to start the reverse process. Please try again."
          redirect_to root_path
        end
      rescue StandardError => e
        Rails.logger.error("Error in stneography_reverse: #{e.message}")
        flash[:alert] = "An error occurred while processing your request. Please try again."
        redirect_to root_path
      end
    end

    def message
      @task_id_reverse = params[:task_id]
      @file_size = params[:filesize].to_i

      if @task_id_reverse.blank? || @file_size.zero?
        render plain: "Invalid request parameters", status: :bad_request
        return
      end

      # Introduce a delay based on file size
      delay = @file_size > 2_000_000 ? 10.5 : 5.5
      sleep delay

      begin
        # Call the task status service
        res = StneographyService.task_status(@task_id_reverse)

        # Check if the response is JSON
        if res.headers["content-type"]&.include?("application/json")
          json_data = JSON.parse(res.body)
          message = json_data["message"]

          # Log and render the message
          Rails.logger.info("Task Message: #{message}")
          @text = message
        else
          # If the response is not JSON, handle it as an error
          Rails.logger.error("Unexpected response format: #{res.headers['content-type']}")
          render plain: "Server returned an unexpected response.", status: :internal_server_error
        end
      rescue JSON::ParserError => e
        Rails.logger.error("Failed to parse JSON in message: #{e.message}")
        render plain: "Server returned an unexpected response.", status: :internal_server_error
      rescue StandardError => e
        Rails.logger.error("Error in message: #{e.message}")
        render plain: "An error occurred while retrieving the task status.", status: :internal_server_error
      end
    end
end
