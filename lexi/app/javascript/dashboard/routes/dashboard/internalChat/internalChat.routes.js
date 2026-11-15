// LEXI replacement (lexi/vite/overrides.json, L-018). fazer.ai's internal chat is a LEXI account
// feature, `internal_chat`, off until a super admin switches it on: the flag hides the menu
// item, and InternalChatGate sends a direct link to the dashboard. Otherwise fazer.ai's routes.
import { frontendURL } from 'dashboard/helper/URLHelper';
import DraftsList from 'dashboard/routes/dashboard/internalChat/DraftsList.vue';
import InternalChatGate from './InternalChatGate.vue';

const INTERNAL_CHAT_PERMISSIONS = ['administrator', 'agent', 'custom_role'];

const EmptyComponent = {
  template: '<div />',
};

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/internal-chat'),
      name: 'internal_chat',
      meta: {
        permissions: INTERNAL_CHAT_PERMISSIONS,
        featureFlag: 'internal_chat',
      },
      component: InternalChatGate,
      children: [
        {
          path: '',
          name: 'internal_chat_home',
          meta: {
            permissions: INTERNAL_CHAT_PERMISSIONS,
            featureFlag: 'internal_chat',
          },
          component: EmptyComponent,
        },
        {
          path: 'channels/:channelId',
          name: 'internal_chat_channel',
          meta: {
            permissions: INTERNAL_CHAT_PERMISSIONS,
            featureFlag: 'internal_chat',
          },
          component: EmptyComponent,
        },
        {
          path: 'channels/:channelId/thread/:messageId',
          name: 'internal_chat_thread',
          meta: {
            permissions: INTERNAL_CHAT_PERMISSIONS,
            featureFlag: 'internal_chat',
          },
          component: EmptyComponent,
        },
        {
          path: 'dm/:channelId',
          name: 'internal_chat_dm',
          meta: {
            permissions: INTERNAL_CHAT_PERMISSIONS,
            featureFlag: 'internal_chat',
          },
          component: EmptyComponent,
        },
        {
          path: 'drafts',
          name: 'internal_chat_drafts',
          meta: {
            permissions: INTERNAL_CHAT_PERMISSIONS,
            featureFlag: 'internal_chat',
          },
          component: DraftsList,
        },
      ],
    },
  ],
};
