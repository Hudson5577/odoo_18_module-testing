from odoo import models, fields

class EstatePropertyImage(models.Model):
    _inherit = "estate.property"

    image_1920 = fields.Image()
