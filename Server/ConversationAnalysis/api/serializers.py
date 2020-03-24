from rest_framework import serializers

from db.models import Conversation, Device, ConversationSegment


class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        exclude = ()


class ConversationSerializer(serializers.ModelSerializer):
    device = serializers.PrimaryKeyRelatedField(many=False, read_only=False, queryset=Device.objects.all())

    class Meta:
        model = Conversation
        fields = ('device', 'uuid', 'date', 'duration')


class ConversationSegmentSerializer(serializers.ModelSerializer):
    conversation = serializers.PrimaryKeyRelatedField(many=False, read_only=False, queryset=Conversation.objects.all())

    class Meta:
        model = ConversationSegment
        fields = ('uuid', 'conversation', 'start_time', 'duration', 'image')
