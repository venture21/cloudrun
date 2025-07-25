// Generated by view binder compiler. Do not edit!
package com.example.geminichat.databinding;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.recyclerview.widget.RecyclerView;
import androidx.viewbinding.ViewBinding;
import androidx.viewbinding.ViewBindings;
import com.example.geminichat.R;
import java.lang.NullPointerException;
import java.lang.Override;
import java.lang.String;

public final class ActivityMainBinding implements ViewBinding {
  @NonNull
  private final ConstraintLayout rootView;

  @NonNull
  public final RecyclerView chatRecyclerView;

  @NonNull
  public final TextView connectionStatus;

  @NonNull
  public final LinearLayout inputLayout;

  @NonNull
  public final EditText messageInput;

  @NonNull
  public final ImageButton sendButton;

  private ActivityMainBinding(@NonNull ConstraintLayout rootView,
      @NonNull RecyclerView chatRecyclerView, @NonNull TextView connectionStatus,
      @NonNull LinearLayout inputLayout, @NonNull EditText messageInput,
      @NonNull ImageButton sendButton) {
    this.rootView = rootView;
    this.chatRecyclerView = chatRecyclerView;
    this.connectionStatus = connectionStatus;
    this.inputLayout = inputLayout;
    this.messageInput = messageInput;
    this.sendButton = sendButton;
  }

  @Override
  @NonNull
  public ConstraintLayout getRoot() {
    return rootView;
  }

  @NonNull
  public static ActivityMainBinding inflate(@NonNull LayoutInflater inflater) {
    return inflate(inflater, null, false);
  }

  @NonNull
  public static ActivityMainBinding inflate(@NonNull LayoutInflater inflater,
      @Nullable ViewGroup parent, boolean attachToParent) {
    View root = inflater.inflate(R.layout.activity_main, parent, false);
    if (attachToParent) {
      parent.addView(root);
    }
    return bind(root);
  }

  @NonNull
  public static ActivityMainBinding bind(@NonNull View rootView) {
    // The body of this method is generated in a way you would not otherwise write.
    // This is done to optimize the compiled bytecode for size and performance.
    int id;
    missingId: {
      id = R.id.chatRecyclerView;
      RecyclerView chatRecyclerView = ViewBindings.findChildViewById(rootView, id);
      if (chatRecyclerView == null) {
        break missingId;
      }

      id = R.id.connectionStatus;
      TextView connectionStatus = ViewBindings.findChildViewById(rootView, id);
      if (connectionStatus == null) {
        break missingId;
      }

      id = R.id.inputLayout;
      LinearLayout inputLayout = ViewBindings.findChildViewById(rootView, id);
      if (inputLayout == null) {
        break missingId;
      }

      id = R.id.messageInput;
      EditText messageInput = ViewBindings.findChildViewById(rootView, id);
      if (messageInput == null) {
        break missingId;
      }

      id = R.id.sendButton;
      ImageButton sendButton = ViewBindings.findChildViewById(rootView, id);
      if (sendButton == null) {
        break missingId;
      }

      return new ActivityMainBinding((ConstraintLayout) rootView, chatRecyclerView,
          connectionStatus, inputLayout, messageInput, sendButton);
    }
    String missingId = rootView.getResources().getResourceName(id);
    throw new NullPointerException("Missing required view with ID: ".concat(missingId));
  }
}
