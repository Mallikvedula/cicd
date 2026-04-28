output "queue_details" {
  description = "A map of queue names and their IDs"
  value = {
    for k, v in genesyscloud_routing_queue.queues : k => {
      name = v.name
      id   = v.id
    }
  }
}
