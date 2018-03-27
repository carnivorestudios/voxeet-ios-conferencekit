// Generated by Apple Swift version 4.0.3 (swiftlang-900.0.74.1 clang-900.0.39.2)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_attribute(external_source_symbol)
# define SWIFT_STRINGIFY(str) #str
# define SWIFT_MODULE_NAMESPACE_PUSH(module_name) _Pragma(SWIFT_STRINGIFY(clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in=module_name, generated_declaration))), apply_to=any(function, enum, objc_interface, objc_category, objc_protocol))))
# define SWIFT_MODULE_NAMESPACE_POP _Pragma("clang attribute pop")
#else
# define SWIFT_MODULE_NAMESPACE_PUSH(module_name)
# define SWIFT_MODULE_NAMESPACE_POP
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <objc/NSObject.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus) || __cplusplus < 201103L
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR __attribute__((enum_extensibility(open)))
# else
#  define SWIFT_ENUM_ATTR
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name) enum _name : _type _name; enum SWIFT_ENUM_ATTR SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME) SWIFT_ENUM(_type, _name)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if __has_feature(modules)
@import QuartzCore;
@import VoxeetSDK;
@import ObjectiveC;
#endif

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

SWIFT_MODULE_NAMESPACE_PUSH("VoxeetConferenceKit")



@interface VTUser (SWIFT_EXTENSION(VoxeetConferenceKit))
- (nonnull instancetype)initWithId:(NSString * _Nonnull)id name:(NSString * _Nullable)name photoURL:(NSString * _Nullable)photoURL;
- (NSString * _Nullable)externalID SWIFT_WARN_UNUSED_RESULT;
- (NSString * _Nullable)externalName SWIFT_WARN_UNUSED_RESULT;
- (NSString * _Nullable)externalPhotoURL SWIFT_WARN_UNUSED_RESULT;
@end



@class NSError;

SWIFT_CLASS("_TtC19VoxeetConferenceKit19VoxeetConferenceKit")
@interface VoxeetConferenceKit : NSObject
/// Voxeet conference kit singleton.
SWIFT_CLASS_PROPERTY(@property (nonatomic, class, readonly, strong) VoxeetConferenceKit * _Nonnull shared;)
+ (VoxeetConferenceKit * _Nonnull)shared SWIFT_WARN_UNUSED_RESULT;
/// Conference appear animation default starts maximized. If false, the conference will appear minimized.
@property (nonatomic) BOOL appearMaximized;
/// The default behavior (false) start the conference on the built in receiver. If true, it will start on the built in speaker.
@property (nonatomic) BOOL defaultBuiltInSpeaker;
/// The default behavior (false) start the conference without video. If true, it will enable the video at conference start.
@property (nonatomic) BOOL defaultVideo;
/// Disable the screen automatic lock of the device if setted to false (if a camera is active, the screen won’t go to sleep).
@property (nonatomic) BOOL screenAutoLock;
/// If true, the conference will behave like a cellular call, if a user hangs up or decline the caller will be disconnected.
@property (nonatomic) BOOL telecom;
/// Enable or disable CallKit (default state: disable).
@property (nonatomic) BOOL callKit;
@property (nonatomic, readonly, copy) NSArray<VTUser *> * _Nonnull users;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
/// Initializing the Voxeet SDK.
/// \param consumerKey To get a consumer key, you need to contact Voxeet in order to use the Voxeet SDK.
///
/// \param consumerSecret To get a consumer secret, you need to contact Voxeet in order to use the Voxeet SDK.
///
/// \param userInfo With this dictionary, you can pass additional information. For example you can add any data you want to initialize a user: <code>["externalId": "1234", "externalName": "User", "externalPhotoUrl": "http://voxeet.com/voxeet-logo.jpg", ...]</code>.
///
/// \param connectSession You may want to manage your user identifier and information like a classic login. You can connect your session later by setting this parameter to false and call <code>VoxeetSDK.shared.session.connect(userID:userInfo:completion:)</code>. If true, the SDK will automatically connect your user (anonymously identified if <code>userInfo</code> parameter is empty). Only works if push notifications capability sets to ON.
///
- (void)initializeWithConsumerKey:(NSString * _Nonnull)consumerKey consumerSecret:(NSString * _Nonnull)consumerSecret;
/// Openning a session is like a login for an external user (your user). However you need to have initialized the SDK with <code>connectSession</code> sets to false. By passing the user ID, it will log the user into our server with your ID (you can additionally pass some extra information with the <code>userInfo</code> parameter).
/// \param userID The user ID is like its identifier, we link this ID to our server’s users.
///
/// \param userInfo With this dictionary, you can pass additional information linked to your user. Here are some examples: <code>["externalName": "User", "externalPhotoUrl": "http://voxeet.com/voxeet-logo.jpg", ...]</code>.
///
/// \param completion A block object to be executed when the server connection sequence ends. This block has no return value and takes a single <code>NSError</code> argument that indicates whether or not the connection to the server succeeded.
///
- (void)openSessionWithUserID:(NSString * _Nonnull)userID userInfo:(NSDictionary<NSString *, id> * _Nullable)userInfo completion:(void (^ _Nullable)(NSError * _Nullable))completion;
/// Opening a session is like a login for a non-voxeet user (or anonymous user). However the SDK needs to be initialized with automaticallyOpenSession set to false. By passing the user identifier, it will link your user into our server.
/// \param user A <code>VTUser</code> object.
///
/// \param completion A block object to be executed when the server connection sequence ends. This block has no return value and takes a single <code>NSError</code> argument that indicates whether or not the connection to the server succeeded.
///
- (void)openSessionWithUser:(VTUser * _Nonnull)user completion:(void (^ _Nullable)(NSError * _Nullable))completion;
/// Updates current user information. You can use this method to update the user identifier, name, avatar URL or any other information you want.
/// \param userID The user ID is linked to Voxeet’s users.
///
/// \param userInfo With this dictionary, you can pass additional information linked to your user. Here are some examples: <code>["externalName": "User", "externalPhotoUrl": "http://voxeet.com/voxeet-logo.jpg", ...]</code>.
///
/// \param completion A block object to be executed when the server connection sequence ends. This block has no return value and takes a single <code>NSError</code> argument that indicates whether or not the connection to the server succeeded.
///
- (void)updateSessionWithUserID:(NSString * _Nonnull)userID userInfo:(NSDictionary<NSString *, id> * _Nullable)userInfo completion:(void (^ _Nullable)(NSError * _Nullable))completion;
/// Updates current user information. You can use this method to update the user identifier, name, avatar URL or any other information you want.
/// \param user A <code>VTUser</code> object.
///
/// \param completion A block object to be executed when the server connection sequence ends. This block has no return value and takes a single <code>NSError</code> argument that indicates whether or not the connection to the server succeeded.
///
- (void)updateSessionWithUser:(VTUser * _Nonnull)user completion:(void (^ _Nullable)(NSError * _Nullable))completion;
/// Closing a session is like a logout. It will stop the socket and stop sending push notifications.
/// \param completion A block object to be executed when the server connection sequence ends. This block has no return value and takes a single <code>NSError</code> argument that indicates whether or not the connection to the server succeeded.
///
- (void)closeSessionWithCompletion:(void (^ _Nullable)(NSError * _Nullable))completion;
/// Starts the conference. As soon as this method is called, it opens the voxeet conference UI.
/// \param id A unique conference identifier.
///
/// \param users If setted, it will display all users in the top bar even if they haven’t join the conference yet (with an inactive state).
///
/// \param invite Send an invitation to others users if true (a VoIP notification is pushed if the application is killed and your app has enable notifications).
///
/// \param success A block object to be executed when the server connection sequence ends. This block has no return value and takes a single <code>[String: Any]?</code> argument which correspond to a JSON object.
///
/// \param fail A block object to be executed when the server connection sequence ends. This block has no return value and takes a single <code>NSError</code> argument that indicates whether or not the connection to the server succeeded.
///
- (void)startConferenceWithId:(NSString * _Nonnull)id users:(NSArray<VTUser *> * _Nullable)users invite:(BOOL)invite success:(void (^ _Nullable)(NSDictionary<NSString *, id> * _Nullable))successCompletion fail:(void (^ _Nullable)(NSError * _Nonnull))failCompletion;
/// Stops the current conference (leave and close voxeet conference UI).
/// \param completion A block object to be executed when the server connection sequence ends. This block has no return value and takes a single <code>NSError</code> argument that indicates whether or not the connection to the server succeeded.
///
- (void)stopConferenceWithCompletion:(void (^ _Nullable)(NSError * _Nullable))completion;
/// Adds one user to the users’ bar manually (conference needs to be started).
/// \param user A <code>VTUser</code> object.
///
- (void)addWithUser:(VTUser * _Nonnull)user;
/// Updates a user’s name, photo, … (conference needs to be started).
/// \param user A <code>VTUser</code> object.
///
- (void)updateWithUser:(VTUser * _Nonnull)user;
/// Updates all users’ information (conference needs to be started).
/// \param users An array of <code>VTUser</code> objects.
///
- (void)updateWithUsers:(NSArray<VTUser *> * _Nonnull)users;
/// Removes one user from the users’ bar manually (after starting a conference).
/// \param user A <code>VTUser</code> object.
///
- (void)removeWithUser:(VTUser * _Nonnull)user;
- (void)maximizeWithAnimated:(BOOL)animated completion:(void (^ _Nullable)(BOOL))completion;
- (void)minimizeWithAnimated:(BOOL)animated completion:(void (^ _Nullable)(BOOL))completion;
@end











SWIFT_MODULE_NAMESPACE_POP
#pragma clang diagnostic pop
