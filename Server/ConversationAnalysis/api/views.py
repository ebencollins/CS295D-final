# Create your views here.
from django.shortcuts import get_object_or_404
from rest_framework import viewsets, mixins
from rest_framework.decorators import action
from rest_framework.response import Response

from api.serializers import ConversationSerializer, DeviceSerializer, ConversationSegmentSerializer
from db.models import Conversation, Device, ConversationSegment


class ConversationViewSet(mixins.CreateModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    queryset = Conversation.objects.all()
    serializer_class = ConversationSerializer

    @action(detail=False, methods=['get'],
            url_path='device/(?P<device>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})')
    def list_action(self, request, device, *args, **kwargs):
        device = get_object_or_404(Device, uuid=device)
        qs = self.queryset.filter(device=device)
        serializer = ConversationSerializer(qs, many=True)
        return Response(serializer.data)


class ConversationSegmentViewSet(mixins.CreateModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    queryset = ConversationSegment.objects.all()
    serializer_class = ConversationSegmentSerializer

    @action(detail=False, methods=['get'],
            url_path='conversation/(?P<conversation>[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})')
    def list_action(self, request, conversation, *args, **kwargs):
        conversation = get_object_or_404(Conversation, uuid=conversation)
        qs = self.queryset.filter(conversation=conversation)
        serializer = ConversationSegmentSerializer(qs, many=True)
        return Response(serializer.data)


class DeviceViewSet(mixins.CreateModelMixin, mixins.RetrieveModelMixin, viewsets.GenericViewSet):
    queryset = Device.objects.all()
    serializer_class = DeviceSerializer
