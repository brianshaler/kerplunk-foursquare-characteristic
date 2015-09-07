_ = require 'lodash'
Promise = require 'when'

module.exports = (System) ->
  Characteristic = System.getModel 'Characteristic'

  preSave = (item) ->
    return item unless item.platform == 'foursquare'
    return item if item.attributes?.characteristic?.length > 0
    return item unless item.data?.id

    item.attributes = {} unless item.attributes

    checkin = item.data

    chars = _.map checkin.venue.categories, (category) ->
      "Venue category: #{category.name}"

    chars.push "Foursquare venue: #{checkin.venue.name}"
    chars.push if checkin.shout?.length > 0
      'Foursquare shout'
    else
      'Foursquare no shout'

    Characteristic
    .getOrCreateArray chars
    .then (characteristics) ->
      item.attributes.characteristic = _.map characteristics, (c) ->
        c._id ? c
      item

  events:
    activityItem:
      save:
        pre: preSave
