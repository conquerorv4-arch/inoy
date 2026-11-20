#define IMGUI_DEFINE_MATH_OPERATORS
#import "DrawView.h"
#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#include "imgui.h"
#include "imgui_impl_metal.h"

bool menu_open = false;

static bool testBool1 = false;
static bool testBool2 = false;
static float testSlider = 50.0f;

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKView *mtkView;
@end

@implementation ImGuiDrawView

- (instancetype)init {
    self = [super init];
    if (self) {
        _device = MTLCreateSystemDefaultDevice();
        _commandQueue = [_device newCommandQueue];

        IMGUI_CHECKVERSION();
        ImGui::CreateContext();

        ImGuiIO &io = ImGui::GetIO();
        io.IniFilename = nullptr;
        io.Fonts->AddFontDefault();

        ImGui::StyleColorsDark();
        ImGuiStyle &style = ImGui::GetStyle();
        style.WindowRounding = 10.0f;
        style.FrameRounding = 6.0f;
        style.ScaleAllSizes(1.1f);

        ImGui_ImplMetal_Init(_device);
    }
    return self;
}

- (void)loadView {
    CGRect bounds = [UIScreen mainScreen].bounds;
    self.view = [[MTKView alloc] initWithFrame:bounds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mtkView = (MTKView *)self.view;
    self.mtkView.device = self.device;
    self.mtkView.delegate = self;
    self.mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    self.mtkView.backgroundColor = [UIColor clearColor];
    self.mtkView.opaque = NO;
}

- (void)updateIOWithTouchEvent:(UIEvent *)event {
    ImGuiIO &io = ImGui::GetIO();
    UITouch *touch = event.allTouches.anyObject;
    if (touch) {
        CGPoint pos = [touch locationInView:self.view];
        io.MousePos = ImVec2(pos.x, pos.y);
    }

    BOOL isDown = NO;
    for (UITouch *t in event.allTouches) {
        if (t.phase != UITouchPhaseEnded && t.phase != UITouchPhaseCancelled) {
            isDown = YES;
            break;
        }
    }
    io.MouseDown[0] = isDown;
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

- (void)drawInMTKView:(MTKView *)view {
    if (!menu_open) {
        return;
    }

    ImGuiIO &io = ImGui::GetIO();
    io.DisplaySize = ImVec2(view.bounds.size.width, view.bounds.size.height);
    CGFloat scale = view.window.screen.nativeScale > 0 ? view.window.screen.nativeScale : 1.0f;
    io.DisplayFramebufferScale = ImVec2(scale, scale);
    io.DeltaTime = 1.0f / 60.0f;

    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    if (!renderPassDescriptor) {
        [commandBuffer commit];
        return;
    }

    id<MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder pushDebugGroup:@"ImGuiMenu"];

    ImGui_ImplMetal_NewFrame(renderPassDescriptor);
    ImGui::NewFrame();

    ImGui::SetNextWindowSize(ImVec2(360, 260), ImGuiCond_FirstUseEver);
    if (ImGui::Begin("Menu", &menu_open)) {
        ImGui::Text("ImGui Overlay Active");
        ImGui::Separator();
        ImGui::Checkbox("Feature 1", &testBool1);
        ImGui::Checkbox("Feature 2", &testBool2);
        ImGui::SliderFloat("Value", &testSlider, 0.0f, 100.0f, "%.0f");
        if (ImGui::Button("Close")) {
            menu_open = false;
            self.view.hidden = YES;
            [self.view setUserInteractionEnabled:NO];
        }
    }
    ImGui::End();

    ImGui::Render();
    ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, renderEncoder);

    [renderEncoder popDebugGroup];
    [renderEncoder endEncoding];
    [commandBuffer presentDrawable:view.currentDrawable];
    [commandBuffer commit];
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {}

@end
