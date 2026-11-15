<script setup>
// LEXI (L-018): fazer.ai's internal chat opens only on accounts with the `internal_chat`
// feature. Once the account is loaded and the feature is off, a direct link to the chat goes
// to the dashboard instead.
import { computed, watch } from 'vue';
import { useRouter } from 'vue-router';
import { useAccount } from 'dashboard/composables/useAccount';
import InternalChatLayout from 'dashboard/routes/dashboard/internalChat/InternalChatLayout.vue';

const router = useRouter();
const { accountId, currentAccount, isCloudFeatureEnabled } = useAccount();

const loaded = computed(() => Boolean(currentAccount.value?.features));
const enabled = computed(
  () => loaded.value && isCloudFeatureEnabled('internal_chat')
);

watch(
  [loaded, enabled],
  () => {
    if (loaded.value && !enabled.value) {
      router.replace({ name: 'home', params: { accountId: accountId.value } });
    }
  },
  { immediate: true }
);
</script>

<template>
  <InternalChatLayout v-if="enabled" />
</template>
