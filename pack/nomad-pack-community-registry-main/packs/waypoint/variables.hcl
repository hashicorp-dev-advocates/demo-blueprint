variable "waypoint_odr_image" {
  description = "The name of the Waypoint on demand runner image to use"
  type        = string
  default     = "nicholasjackson/waypoint-custom-odr:0.2.0"
}

variable "waypoint_odr_additional_certs" {
  description = "Additional certificates to add to the ODR image, sets the environment variable EXTRA_CERTS in the runner profile"
  type        = string
  default     = ""
}
