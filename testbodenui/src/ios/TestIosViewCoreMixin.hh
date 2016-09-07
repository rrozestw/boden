#ifndef BDN_TEST_TestIosViewCore_H_
#define BDN_TEST_TestIosViewCore_H_


#include <bdn/View.h>
#import <bdn/ios/ViewCore.hh>
#import <bdn/ios/UiProvider.hh>
#import <bdn/ios/util.hh>

namespace bdn
{
namespace test
{


/** A mixin class that adds implementations of ios view specific functionality on top of
 the base class specified in the template parameter BaseClass.*/
template<class BaseClass>
class TestIosViewCoreMixin : public BaseClass
{
protected:
    
    void initCore() override
    {
        BaseClass::initCore();
        
        _pIosViewCore = cast<bdn::ios::ViewCore>( BaseClass::_pView->getViewCore() );
        REQUIRE( _pIosViewCore!=nullptr );
        
        _pUIView = _pIosViewCore->getUIView();
        REQUIRE( _pUIView!=nullptr );
    }
    
    IUiProvider& getUiProvider() override
    {
        return bdn::ios::UiProvider::get();
    }
    
    void verifyCoreVisibility() override
    {
        bool expectedVisible = BaseClass::_pView->visible();
        
        REQUIRE( _pUIView.hidden == !expectedVisible );
    }
    
    Rect getFrameRect() const
    {
        return bdn::ios::iosRectToRect( _pUIView.frame);
    }
    
    void verifyInitialDummyCoreBounds() override
    {        
        Rect rect = getFrameRect();
        
        // even the dummy rects of newly created controls will sometimes have a valid
        // size from the start.
        
        REQUIRE( rect.getPosition() == Point() );
        REQUIRE( rect.height >= 0);
        REQUIRE( rect.width >= 0);
    }
    
    void verifyCoreBounds() override
    {        
        Rect rect = getFrameRect();
        Rect expectedRect = BaseClass::_pView->bounds();
        
        REQUIRE( rect == expectedRect );
    }
    
    
    void verifyCorePadding() override
    {
        // the padding is not reflected in UIKit properties.
        // So nothing to test here.
    }
    
    
    P<bdn::ios::ViewCore>  _pIosViewCore;
    UIView*                _pUIView;
};
        
        
        
}
}


#endif
