<script setup>
// LEXI replacement (lexi/vite/overrides.json, L-016) for fazer.ai's "Upgrade to Pro"
// nudge. The internal chat limits of fazer.ai's open code stay as they are; this
// component explains the limit a user ran into, without selling a subscription.
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useInternalChatPro } from 'dashboard/composables/useInternalChatPro';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';

const props = defineProps({
  feature: {
    type: String,
    default: 'polls',
    validator: v => ['polls', 'private_channels', 'search'].includes(v),
  },
  inline: {
    type: Boolean,
    default: false,
  },
});

const { t } = useI18n({
  messages: {
    en: {
      LIMITS: {
        POLLS_TITLE: 'Polls are off',
        POLLS: 'Polls are turned off on this installation.',
        PRIVATE_CHANNELS_TITLE: 'Private channel limit',
        PRIVATE_CHANNELS:
          'The account has reached its limit of private channels: {limit}. To free a slot, archive a private channel you no longer need.',
        SEARCH: 'Showing messages from the last {days} days.',
        OK: 'Got it',
      },
    },
    ru: {
      LIMITS: {
        POLLS_TITLE: 'Опросы выключены',
        POLLS: 'На этой установке опросы выключены.',
        PRIVATE_CHANNELS_TITLE: 'Предел приватных каналов',
        PRIVATE_CHANNELS:
          'Достигнут предел приватных каналов в аккаунте: {limit}. Чтобы освободить место, архивируйте приватный канал, который больше не нужен.',
        SEARCH: 'Показаны сообщения за последние {days} дней.',
        OK: 'Понятно',
      },
    },
  },
});
const { maxPrivateChannels, searchHistoryDays } = useInternalChatPro();

const dialogRef = ref(null);

const notice = computed(() => {
  switch (props.feature) {
    case 'private_channels':
      return {
        title: t('LIMITS.PRIVATE_CHANNELS_TITLE'),
        description: t('LIMITS.PRIVATE_CHANNELS', {
          limit: maxPrivateChannels.value,
        }),
      };
    case 'search':
      return {
        title: '',
        description: t('LIMITS.SEARCH', { days: searchHistoryDays.value }),
      };
    default:
      return { title: t('LIMITS.POLLS_TITLE'), description: t('LIMITS.POLLS') };
  }
});

function open() {
  dialogRef.value?.open();
}

function close() {
  dialogRef.value?.close();
}

defineExpose({ open });
</script>

<template>
  <p
    v-if="inline"
    class="rounded-lg bg-n-alpha-1 px-3 py-2 text-sm text-n-slate-10"
  >
    {{ notice.description }}
  </p>
  <Dialog
    v-else
    ref="dialogRef"
    :title="notice.title"
    :description="notice.description"
    :confirm-button-label="t('LIMITS.OK')"
    :show-cancel-button="false"
    width="sm"
    @confirm="close"
  />
</template>
