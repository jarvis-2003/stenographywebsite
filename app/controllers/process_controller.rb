class ProcessController < ApplicationController
  def encryption_form
  end
  def stneography
    image = params[:image]
    text = params[:hidden_text]
    puts text

    if image.present? && text.present?
      begin
        response = StneographyService.process(text, image)
        puts response
        @task_id = response["taskid"]
        redirect_to download_path(taskid: @task_id, filesize: File.size(image))
      rescue => e
        puts e.message
      end
    else
      render :encryption_form
    end
  end

  def download
    @task_id = params[:taskid]
    @file_size = params[:filesize]

    delay = @file_size.to_i > 2_000_000 ? 10.5 : 5.5
    sleep delay

    response = StneographyService.task_status(@task_id)

    if response.success?
      # Send the image file for download
      send_data(response.body,
                filename: "output_image.png",
                type: response.headers["content-type"],
                disposition: "attachment")

      flash[:notice] = "Try Decrypting it to get the message back"
    else
      # If the task fails, render an error message
      render plain: "Failed to download the file", status: :bad_request
    end
  end
end
