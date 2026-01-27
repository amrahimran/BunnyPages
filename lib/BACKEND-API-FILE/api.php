<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Http\Request;

// API Auth Controller
use App\Http\Controllers\Api\AuthController;
//use App\Http\Controllers\AuthController; //-->USE FOR FLUTTER REGISTRATION


use App\Http\Controllers\ProductController;
use App\Http\Controllers\ReviewController;
use App\Http\Controllers\WishlistController;
use App\Http\Controllers\CartController;
use App\Http\Controllers\OrderController;

use App\Http\Controllers\Admin\ProductController as AdminProductController;
use App\Http\Controllers\Admin\OrderController as AdminOrderController;
use App\Http\Controllers\Admin\AdminController;
use App\Http\Middleware\AdminMiddleware;



// PUBLIC ROUTES

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::get('/products', [ProductController::class, 'apiIndex2']);
Route::get('/products/{id}', [ProductController::class, 'apiShow']);


// USER PROTECTED ROUTES

Route::middleware('auth:sanctum')->group(function () {

    Route::post('/logout', [AuthController::class, 'logout']);

    // Reviews
    Route::post('/products/{id}/review', [ReviewController::class, 'store']);
    Route::delete('/reviews/{id}', [ReviewController::class, 'destroy']);

    // Wishlist
    Route::post('/wishlist/add/{product}', [WishlistController::class, 'add']);
    Route::get('/wishlist', [WishlistController::class, 'index']);
    Route::delete('/wishlist/remove/{id}', [WishlistController::class, 'remove']);

    // Cart
    Route::post('/cart/add/{id}', [CartController::class, 'add']);
    Route::post('/cart/update/{id}', [CartController::class, 'updateQuantity']);
    Route::post('/cart/remove/{id}', [CartController::class, 'remove']);
    Route::get('/cart', [CartController::class, 'index']);

    // Orders
    Route::post('/checkout/place-order', [OrderController::class, 'placeOrder']);
    Route::get('/orders', [OrderController::class, 'index']);

    // Fetch authenticated user
    Route::get('/user', function (Request $request) {
        return response()->json([
            'data' => [
                'id' => $request->user()->id,
                'name' => $request->user()->name,
                'email' => $request->user()->email,
                'phone' => $request->user()->phone,
                'shipping_address' => $request->user()->shipping_address,
                'profile_photo_url' => $request->user()->profile_photo_url,
            ]
        ]);
    });
});

// ADMIN ROUTES

Route::middleware(['auth:sanctum', AdminMiddleware::class])->group(function () {
    Route::get('/admin/dashboard', [AdminController::class, 'index']);

    Route::apiResource('/admin/products', AdminProductController::class);
    Route::apiResource('/admin/orders', AdminOrderController::class);
});

//flutter routes
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']); // already exists
    Route::middleware('auth:sanctum')->put('/user/update', [AuthController::class, 'update']);
});

Route::middleware('auth:sanctum')->post('/orders', [OrderController::class, 'store']);

//firebase fcm

Route::middleware('auth:sanctum')->post('/save-fcm-token', function (Request $request) {
    $request->user()->update([
        'fcm_token' => $request->fcm_token
    ]);

    return response()->json(['success' => true]);
});
