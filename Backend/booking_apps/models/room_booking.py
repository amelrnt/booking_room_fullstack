from datetime import datetime

from odoo import api, fields, models
from odoo.exceptions import UserError, ValidationError


class RoomBooking(models.Model):
    _name = "room.booking"
    _inherit = ['mail.thread', 'mail.activity.mixin']
    _description = "Room Booking"
    _order = 'id desc'

    name = fields.Char()
    conference_room_id = fields.Many2one('conference.room', "Ruangan", required=True)
    employee_id = fields.Many2one('hr.employee', 'Nama Pemesanan', required=True)
    booking_date = fields.Date(required=True)
    state = fields.Selection([
        ('draft', 'Draft'),
        ('on_going', 'On Going'),
        ('done', 'Done')
    ], default="draft")
    description = fields.Text("Keterangan")
    room_type = fields.Selection(related="conference_room_id.room_type")
    employee_name = fields.Char(related="employee_id.name")
    room_name = fields.Char(related="conference_room_id.name")

    @api.constrains('conference_room_id', 'booking_date')
    def _check_double_booking(self):
        for rec in self:
          if self.search([('conference_room_id', '=', rec.conference_room_id.id),
                          ('booking_date', '=', rec.booking_date),
                          ('id', '!=', rec.id)]):
            raise UserError("Ruangan ini telah di book untuk tanggal yang anda pilih")

    def set_booking_on_going(self):
        for rec in self:
            rec.state = 'on_going'
        
    def set_booking_done(self):
        for rec in self:
            rec.state = 'done'

    @api.model
    def api_set_booking_on_going(self, booking_id):
        try:
            if not booking_id:
                return {'status': 'failed', 'message': 'booking_id is required'}

            book = self.browse(booking_id)
            if not book.exists():
                return {'status': 'failed', 'message': 'Booking not found'}

            if book.state != 'draft':
                return {
                    'status': 'failed',
                    'message': f"Cannot set on going in current state ({book.state})"
                }
            book.state = 'on_going'
            
            return {
                'status': 'success',
                'message': 'Room Booking state successfully updated to on going'
            }

        except Exception as e:
            return {
                'status': 'error',
                'message': f'Server error: {str(e)}'
            }
    @api.model
    def api_set_booking_done(self, booking_id):
        try:
            if not booking_id:
                return {'status': 'failed', 'message': 'booking_id is required'}

            book = self.browse(booking_id)
            if not book.exists():
                return {'status': 'failed', 'message': 'Booking not found'}

            if book.state != 'on_going':
                return {
                    'status': 'failed',
                    'message': f"Cannot set done in current state ({book.state})"
                }
            book.state = 'done'
            
            return {
                'status': 'success',
                'message': 'Room Booking state successfully updated to done'
            }

        except Exception as e:
            return {
                'status': 'error',
                'message': f'Server error: {str(e)}'
            }

    @api.model
    def create(self, vals):
        if not vals.get('name'):
            conference_room = self.env['conference.room'].browse(vals.get('conference_room_id'))
            room_type = conference_room.room_type
            booking_date = datetime.strptime(vals.get('booking_date'), '%Y-%m-%d').date()
            date_str = booking_date.strftime("%Y%m%d")

            seq = self.env['ir.sequence'].next_by_code('room.booking.sequence')
            vals['name'] = f"{room_type}{date_str}{seq}"

        res = super(RoomBooking, self).create(vals)
        return res