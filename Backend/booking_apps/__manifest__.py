# -*- coding: utf-8 -*-
{
    "name": "Booking System",
    "summary": "Booking System",
    "description": """
    Booking system modules created to acomplished technical test from Tunas Ridean
    """,
    "author": "Amelia Rosanti",
    # "category": "Sales/CRM",
    "version": "17.0.1.0.0",
    'license': 'LGPL-3',
    "depends": [
        "base",
        "hr"
    ],
    "data": [
        "data/sequence.xml",
        "views/room_views.xml",
        "views/booking_views.xml",
        "security/ir.model.access.csv",
        # "wizard/change_approver.xml",
    ],
}
