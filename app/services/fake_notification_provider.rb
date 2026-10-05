class FakeNotificationProvider
  def self.send_notification(idempotency_key:)
    if delivered_keys.include?(idempotency_key)
      Rails.logger.info "🔁 Provider already processed #{idempotency_key}"
      return :already_processed
    end

    delivered_keys << idempotency_key

    Rails.logger.info "📧 PROVIDER SENT notification with key #{idempotency_key}"
    :sent
  end

  def self.delivered_keys
    @delivered_keys ||= []
  end
end