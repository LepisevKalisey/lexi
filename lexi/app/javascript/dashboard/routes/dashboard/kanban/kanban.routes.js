// LEXI replacement (lexi/vite/overrides.json, L-016). fazer.ai Kanban is a paid closed
// module: the open code only has its menu item and a page selling the subscription.
// The route stays because the sidebar resolves 'kanban_view'. The `kanban` feature flag,
// which LEXI accounts do not have, hides the menu item; a direct link opens the dashboard.
import { frontendURL } from 'dashboard/helper/URLHelper';

export const routes = [
  {
    path: frontendURL('accounts/:accountId/kanban'),
    name: 'kanban_view',
    meta: {
      permissions: ['administrator', 'agent', 'custom_role'],
      featureFlag: 'kanban',
    },
    redirect: to => ({
      name: 'home',
      params: { accountId: to.params.accountId },
    }),
  },
];
