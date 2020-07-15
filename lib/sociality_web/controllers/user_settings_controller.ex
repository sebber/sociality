defmodule SocialityWeb.UserSettingsController do
  use SocialityWeb, :controller

  alias Sociality.Accounts
  alias Sociality.Avatar
  alias SocialityWeb.UserAuth

  plug :assign_email_and_password_changesets

  def edit(conn, _params) do
    render(conn, "edit.html")
  end

  def update_avatar(conn, %{"user" => %{"photo" => photo}}) do
    user = conn.assigns.current_user

    with {:ok, filename} <- Avatar.store({photo, user}),
         {:ok, user} <- Accounts.apply_avatar(user, filename) do
      conn
      |> put_flash(:info, "uploaded!!")
      |> redirect(to: Routes.user_settings_path(conn, :edit))
    else
      _ ->
        conn
        |> put_flash(:error, "didn't work :'(")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def update_name(conn, %{"user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_name(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Name updated successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", name_changeset: changeset)
    end
  end

  def update_email(conn, %{"current_password" => password, "user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_update_email_instructions(
          applied_user,
          user.email,
          &Routes.user_settings_url(conn, :confirm_email, &1)
        )

        conn
        |> put_flash(
          :info,
          "A link to confirm your e-mail change has been sent to the new address."
        )
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      {:error, changeset} ->
        render(conn, "edit.html", email_changeset: changeset)
    end
  end

  def confirm_email(conn, %{"token" => token}) do
    case Accounts.update_user_email(conn.assigns.current_user, token) do
      :ok ->
        conn
        |> put_flash(:info, "E-mail changed successfully.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))

      :error ->
        conn
        |> put_flash(:error, "Email change link is invalid or it has expired.")
        |> redirect(to: Routes.user_settings_path(conn, :edit))
    end
  end

  def update_password(conn, %{"current_password" => password, "user" => user_params}) do
    user = conn.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Password updated successfully.")
        |> put_session(:user_return_to, Routes.user_settings_path(conn, :edit))
        |> UserAuth.log_in_user(user)

      {:error, changeset} ->
        render(conn, "edit.html", password_changeset: changeset)
    end
  end

  defp assign_email_and_password_changesets(conn, _opts) do
    user = conn.assigns.current_user

    conn
    |> assign(:avatar_changeset, Accounts.change_user_avatar(user))
    |> assign(:name_changeset, Accounts.change_user_name(user))
    |> assign(:email_changeset, Accounts.change_user_email(user))
    |> assign(:password_changeset, Accounts.change_user_password(user))
  end
end
