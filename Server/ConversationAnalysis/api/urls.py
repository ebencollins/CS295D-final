from django.urls import path, include
from rest_framework.routers import SimpleRouter

from api import views
from api.views import ConversationSegmentViewSet

router = SimpleRouter()
router.register(r'devices', views.DeviceViewSet)
router.register(r'conversations', views.ConversationViewSet)
router.register(r'conversation-segments', ConversationSegmentViewSet)

urlpatterns = [
    path('test', views.ConversationViewSet.as_view(actions={'get': 'list'})),
    path('', include(router.urls)),
]
