#include "../include/bdn/android/ListViewCore.h"
#include <bdn/android/ListViewCore.h>
#include <bdn/android/wrapper/NativeAdapterViewOnItemClickListener.h>
#include <bdn/android/wrapper/NativeListAdapter.h>
#include <bdn/android/wrapper/NativeListView.h>

namespace bdn::android
{
    ListViewCore::ListViewCore(const std::shared_ptr<bdn::UIProvider> &uiProvider)
        : ViewCore(uiProvider, createAndroidViewClass<wrapper::NativeListView>(uiProvider)),
          _jNativeListView(getJViewAS<wrapper::NativeListView>()), _jListView(_jNativeListView.getListView()),
          _jNativeListAdapter(_jListView.cast<wrapper::View>())
    {
        _jListView.setDescendantFocusability(0x00060000);
        _jListView.setChoiceMode(0x00000001);
        _jListView.setAdapter(wrapper::ListAdapter(_jNativeListAdapter.getRef_()));

        wrapper::NativeAdapterViewOnItemClickListener listener;
        _jListView.setOnItemClickListener(listener.cast<wrapper::OnItemClickListener>());

        enableRefresh.onChange() += [this](auto va) { _jNativeListView.setEnabled(va->get()); };
    }

    void ListViewCore::refreshDone() { _jNativeListView.setRefreshing(false); }

    void ListViewCore::fireRefresh() { _refreshCallback.fire(); }

    void ListViewCore::initTag()
    {
        ViewCore::initTag();

        auto tag = bdn::java::wrapper::NativeWeakPointer(shared_from_this());
        _jListView.setTag(tag);
    }

    void ListViewCore::reloadData() { _jNativeListAdapter.notifyDataSetChanged(); }
}