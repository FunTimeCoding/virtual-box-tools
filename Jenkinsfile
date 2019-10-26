pipeline {
    agent any
    stages {
        stage('Check') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh 'script/check.sh'
                checkstyle pattern: 'build/log/checkstyle-*.xml'
            }
        }
        stage('Measure') {
            steps {
                sh 'script/measure.sh'
            }
        }
        stage('Test') {
            when {
                expression {
                    currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                sh 'script/test.sh'
                junit 'reports/**/*.xml'
            }
        }
        stage('Package') {
            steps {
                sh 'script/package.sh'
                archiveArtifacts artifacts: 'build/*.deb', fingerprint: true
            }
        }
        stage('Publish') {
            steps {
                sh 'script/publish.sh'
            }
        }
    }
}
