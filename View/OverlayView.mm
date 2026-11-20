#import "OverlayView.h"
#import "../Image/font.h"
#import "../Image/Icon.h"
#import "../Image/Iconcpp.h"
#import <objc/runtime.h>
//#import "API.h"

@implementation OverlayView
    ImFont *_espFont;
    ImFont *_iconFont;

- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control :(mi*)menu {
    self.moduleControl = control;
    self.mi = menu;

    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.preferredFramesPerSecond = 120;

        self.device = MTLCreateSystemDefaultDevice();
        if (!self.device) {
            return nil;
        }
        self.delegate = self;

        self.commandQueue = [self.device newCommandQueue];
        self.loader = [[MTKTextureLoader alloc] initWithDevice:self.device];

        IMGUI_CHECKVERSION();
        ImGui::CreateContext();
        ImGuiIO& io = ImGui::GetIO();
        (void)io;

        ImGui::StyleColorsDark();

        BOOL addedCustomFont = NO;
        #if defined(Fontdata) && defined(Fontsize)
        if (Fontdata != nullptr && Fontsize > 0) {
            ImFontConfig config;
            config.FontDataOwnedByAtlas = false;
            ImFont *loadedFont = io.Fonts->AddFontFromMemoryTTF((void *)Fontdata, (int)Fontsize, 30.0f, &config, io.Fonts->GetGlyphRangesChineseFull());
            if (loadedFont != nullptr) {
                _espFont = loadedFont;
                addedCustomFont = YES;
            }
        }
        #endif

        if (!addedCustomFont) {
            ImFontConfig defaultCfg;
            defaultCfg.SizePixels = 16.0f;
            _espFont = io.Fonts->AddFontDefault(&defaultCfg);
        }

        static const ImWchar icons_ranges[] = { 0xf000, 0xf3ff, 0 };
        ImFontConfig icons_config;
        icons_config.FontDataOwnedByAtlas = false;
        icons_config.MergeMode = true;
        icons_config.PixelSnapH = true;

        #if defined(font_awesome_data) && defined(font_awesome_size)
        if (font_awesome_data != nullptr && font_awesome_size > 0) {
            _iconFont = io.Fonts->AddFontFromMemoryCompressedTTF(font_awesome_data, (int)font_awesome_size, 20.0f, &icons_config, icons_ranges);
        }
        #endif

        if (_iconFont != nullptr) {
            _iconFont->FontSize = 5.0f;
        }

        if (io.Fonts->Fonts.Size == 0) {
            io.Fonts->AddFontDefault();
        }

        io.DisplaySize.x = self.frame.size.width * UIScreen.mainScreen.nativeScale;
        io.DisplaySize.y = self.frame.size.height * UIScreen.mainScreen.nativeScale;

        ImGui::StyleColorsDark();
        ImGui_ImplMetal_Init(self.device);
        [self.mi setOverlayView:self];
    }
    return self;
}

+ (void)load {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
}

- (bool)ishowM {
    return self.moduleControl ? self.moduleControl->menuStatus : false;
}

- (void)drawInMTKView:(MTKView *)view {
    view.sampleCount = 4;
    view.clearColor = MTLClearColorMake(0.0f, 0.0f, 0.0f, 0.0f);

    struct timespec current_timespec;
    static double g_Time = 0.0;
    clock_gettime(CLOCK_MONOTONIC, &current_timespec);
    double current_time = (double)(current_timespec.tv_sec) + (current_timespec.tv_nsec / 1000000000.0);
    ImGui::GetIO().DeltaTime = g_Time > 0.0 ? (float)(current_time - g_Time) : (float)(1.0f / 120.0f);
    g_Time = current_time;

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil) {
        ImGui_ImplMetal_NewFrame(renderPassDescriptor);
        ImGui::NewFrame();

        if (self.moduleControl && self.moduleControl->menuStatus && self.mi) {
            [self.mi drawMenuWindow];
        }

        ImGui::Render();
        ImDrawData *drawData = ImGui::GetDrawData();
        id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"SwiftGUI"];
        ImGui_ImplMetal_RenderDrawData(drawData, commandBuffer, renderEncoder);

        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];

    if (hitView == self && (!self.moduleControl || !self.moduleControl->menuStatus)) {
        return nil;
    }
    return hitView;
}

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self];
    ImGuiIO &io = ImGui::GetIO();
    io.AddMousePosEvent(touchLocation.x * UIScreen.mainScreen.nativeScale, touchLocation.y * UIScreen.mainScreen.nativeScale);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches) {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled) {
            hasActiveTouch = YES;
            break;
        }
    }
    io.AddMouseButtonEvent(0, hasActiveTouch);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self updateIOWithTouchEvent:event];
}

@end
