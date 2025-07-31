FROM manjarolinux/base:latest

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG USER_NAME=people

RUN pacman -Sy \
 && pacman -S --noconfirm git curl wget sudo \
 && ( \
    # 既存のbuilderユーザー（UID:1000）をチェック \
    if id -u builder >/dev/null 2>&1 && [ "$(id -u builder)" = "${USER_ID}" ]; then \
        echo "既存のbuilderユーザーを${USER_NAME}に変更します"; \
        # builderユーザーの名前とホームディレクトリを変更 \
        usermod -l ${USER_NAME} builder; \
        usermod -d /home/${USER_NAME} -m ${USER_NAME}; \
        # 既存のbuilderグループも変更 \
        if getent group builder >/dev/null 2>&1; then \
            groupmod -n ${USER_NAME} builder; \
        fi; \
    else \
        # 指定されたGROUP_IDのグループが存在しない場合は作成 \
        if ! getent group ${GROUP_ID} >/dev/null 2>&1; then \
            groupadd -g ${GROUP_ID} ${USER_NAME}; \
        fi; \
        # 指定されたUSER_IDのユーザーが存在しない場合は作成 \
        if ! id -u ${USER_ID} >/dev/null 2>&1; then \
            useradd -m -u ${USER_ID} -g ${GROUP_ID} -G wheel -s /bin/bash ${USER_NAME}; \
        else \
            echo "警告: UID ${USER_ID} は既に使用されています"; \
            exit 1; \
        fi; \
    fi \
) \
 && echo "${USER_NAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${USER_NAME}
