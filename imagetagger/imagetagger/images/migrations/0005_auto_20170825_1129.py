# -*- coding: utf-8 -*-
# Generated by Django 1.11.3 on 2017-08-25 09:29
from __future__ import unicode_literals

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('images', '0004_auto_20170825_1114'),
    ]

    operations = [
        migrations.AlterField(
            model_name='imageset',
            name='team',
            field=models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='image_sets', to='users.Team'),
        ),
    ]
