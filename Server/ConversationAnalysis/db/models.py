from django.db import models

from db import utils


class Device(models.Model):
    uuid = models.UUIDField(primary_key=True, editable=True,
                            help_text="UUID of the device (as displayed)")


class Conversation(models.Model):
    uuid = models.UUIDField(primary_key=True, editable=True, help_text="UIUD of the recording")
    device = models.ForeignKey(Device, on_delete=models.PROTECT, help_text="Device that recorded the conversation")
    date = models.DateTimeField(help_text="Date the conversation took place")
    date_uploaded = models.DateTimeField(auto_now_add=True, help_text="Date the conversation was uploaded")
    duration = models.IntegerField(help_text="Duration of the conversation")

    class Meta:
        unique_together = ('device', 'date')


class ConversationSegment(models.Model):
    uuid = models.UUIDField(primary_key=True, editable=True, help_text="UUID of the conversations segment")
    conversation = models.ForeignKey(Conversation, on_delete=models.CASCADE, help_text="Associated conversation")
    start_time = models.IntegerField(help_text="Start time in seconds relating to the conversation duration")
    duration = models.IntegerField(help_text="Duration of the segment")
    image = models.ImageField(upload_to=utils.path_and_rename, unique=True,
                              help_text="Media path of the saved gammatone")
