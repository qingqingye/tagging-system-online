# -*- coding: utf-8 -*-
# Generated by Django 1.11.3 on 2017-08-26 12:24
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('annotations', '0004_auto_20170826_1211'),
    ]

    operations = [
        migrations.RenameField(
            model_name='annotation',
            old_name='type',
            new_name='annotation_type',
        ),
        migrations.RenameField(
            model_name='export',
            old_name='type',
            new_name='export_type',
        ),
    ]
