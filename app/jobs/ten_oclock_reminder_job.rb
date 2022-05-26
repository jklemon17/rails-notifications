class TenOclockReminderJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Push::Notify.send(title: "It's 10:00pm", 
            contents: "Shouldn't you be going to bed now?",
            type: "time_reminder", 
            )
  end
end