from odoo import api, fields, models
from odoo.exceptions import UserError, ValidationError


class ConfrenceRoom(models.Model):
    _name = "conference.room"
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _description = "Conference Rooms"
    _order = 'id desc'

    name = fields.Char(required=True)
    room_type = fields.Selection([
        ('small', 'Meeting Room Kecil'),
        ('big', 'Meeting Room Besar'),
        ('hall', 'Aula')
        ], 'Tipe Ruangan', required=True
    )
    room_location = fields.Selection([
        ('1a', '1A'),
        ('1b', '1B'),
        ('1c', '1C'),
        ('2a', '2A'),
        ('2b', '2B'),
        ('2c', '2C'),
        ], 'Lokasi Ruangan', required=True
    )
    room_photos_filename = fields.Char(required=True)
    room_photos = fields.Binary("Foto Ruangan", required=True)
    room_capacity = fields.Integer("Kapasitas Ruangan", required=True)
    description = fields.Text("Keterangan")

    @api.constrains('room_photos_filename')
    def _check_image_format(self):
        for rec in self:
            filename_extension = rec.room_photos_filename.split(".")[-1].lower()
            if filename_extension not in ('jpeg', 'png', 'gif', 'pdf'):
                raise ValidationError("Upload foto dengan format image")

    @api.constrains('name')
    def _check_duplicate_name(self):
        for rec in self:
            if self.search([('name', '=', rec.name), ('id', '!=', rec.id)]):
                raise UserError("Telah ada ruangan lain dengan nama ini")

    

