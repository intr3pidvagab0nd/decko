def content
  return "" unless left&.real?
  I18n.localize left.created_at, format: :card_dayofwk_min_tz
end

# view :core, :raw
