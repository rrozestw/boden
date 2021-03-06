#import <bdn/foundationkit/stringUtil.hh>
#include <bdn/ios/SwitchCore.hh>

@implementation BdnIosSwitchClickManager

- (void)clicked
{
    if (auto core = self.core.lock()) {
        core->handleClick();
    }
}

@end

@implementation BdnIosSwitchComposite

// Use systemLayoutSizeFittingSize instead of intrinsicContentSize
- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize
{
    CGFloat minMargin = 10.;
    if (self.uiLabel.text.length == 0)
        minMargin = 0;
    CGSize switchSize = [self.uiSwitch systemLayoutSizeFittingSize:targetSize];
    CGSize labelSize = [self.uiLabel systemLayoutSizeFittingSize:targetSize];
    return CGSizeMake(switchSize.width + labelSize.width + minMargin, fmax(switchSize.height, labelSize.height));
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];

    CGRect compositeBounds = self.bounds;
    CGRect switchBounds = self.uiSwitch.bounds;
    CGRect labelBounds = self.uiLabel.bounds;

    // Center switch vertically in composite
    CGRect switchFrame = CGRectMake(compositeBounds.size.width - switchBounds.size.width,
                                    compositeBounds.size.height / 2. - switchBounds.size.height / 2.,
                                    switchBounds.size.width, switchBounds.size.height);
    self.uiSwitch.frame = switchFrame;

    // Center label vertically in composite
    CGRect labelFrame = CGRectMake(0, compositeBounds.size.height / 2. - labelBounds.size.height / 2.,
                                   labelBounds.size.width, labelBounds.size.height);
    self.uiLabel.frame = labelFrame;

    if (auto viewCore = self.viewCore.lock()) {
        viewCore->frameChanged();
    }
}
@end

namespace bdn::ui::detail
{
    CORE_REGISTER(Switch, bdn::ui::ios::SwitchCore, Switch)
}

namespace bdn::ui::ios
{
    BdnIosSwitchComposite *SwitchCore::createSwitchComposite()
    {
        BdnIosSwitchComposite *switchComposite = [[BdnIosSwitchComposite alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];

        switchComposite.uiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [switchComposite addSubview:switchComposite.uiSwitch];

        switchComposite.uiLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        [switchComposite addSubview:switchComposite.uiLabel];

        return switchComposite;
    }

    SwitchCore::SwitchCore(const std::shared_ptr<ViewCoreFactory> &viewCoreFactory)
        : ViewCore(viewCoreFactory, createSwitchComposite())
    {}

    void SwitchCore::init()
    {
        ViewCore::init();
        _composite = (BdnIosSwitchComposite *)uiView();

        _clickManager = [[BdnIosSwitchClickManager alloc] init];
        _clickManager.core = shared_from_this<SwitchCore>();

        [_composite.uiSwitch addTarget:_clickManager
                                action:@selector(clicked)
                      forControlEvents:UIControlEventTouchUpInside];

        label.onChange() += [=](auto &property) {
            _composite.uiLabel.text = fk::stringToNSString(label);
            [_composite.uiLabel sizeToFit];
        };

        on.onChange() += [=](auto &property) { ((BdnIosSwitchComposite *)_composite).uiSwitch.on = on; };
    }

    SwitchCore::~SwitchCore()
    {
        auto switchComposite = (BdnIosSwitchComposite *)_composite;
        [switchComposite.uiSwitch removeTarget:_clickManager action:nil forControlEvents:UIControlEventTouchUpInside];
    }

    void SwitchCore::handleClick()
    {
        _composite = (BdnIosSwitchComposite *)uiView();
        on = _composite.uiSwitch.on;
        _clickCallback.fire();
    }
}
