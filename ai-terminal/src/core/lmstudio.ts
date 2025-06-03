import { LMStudioClient } from '@lmstudio/sdk';
import type { Model, ChatMessage } from '@lmstudio/sdk';
import { EventEmitter } from 'events';

export interface LMStudioConfig {
  baseUrl?: string;
  remoteUrl?: string;
  useRemote?: boolean;
  model?: string;
  temperature?: number;
  maxTokens?: number;
}

export class LMStudioService extends EventEmitter {
  private client: LMStudioClient;
  private model: Model | null = null;
  private config: LMStudioConfig;

  constructor(config: LMStudioConfig = {}) {
    super();
    // Load from environment variables first, then config file
    let defaultConfig = {
      baseUrl: process.env.LMSTUDIO_BASE_URL || 'ws://localhost:1234',
      remoteUrl: process.env.LMSTUDIO_REMOTE_URL || process.env.LMSTUDIO_DRAGON_URL, // support old env var
      useRemote: process.env.LMSTUDIO_USE_REMOTE === 'true' || process.env.LMSTUDIO_USE_DRAGON === 'true',
      model: process.env.LMSTUDIO_MODEL || 'qwen3-8b',
      temperature: process.env.LMSTUDIO_TEMPERATURE ? parseFloat(process.env.LMSTUDIO_TEMPERATURE) : 0.7,
      maxTokens: process.env.LMSTUDIO_MAX_TOKENS ? parseInt(process.env.LMSTUDIO_MAX_TOKENS) : 200,
    };
    
    try {
      const configPath = new URL('../../config/default.json', import.meta.url);
      const configFile = JSON.parse(require('fs').readFileSync(configPath, 'utf-8'));
      defaultConfig = { ...defaultConfig, ...configFile.lmstudio };
    } catch {
      // Use defaults if config file not found
    }
    
    this.config = {
      baseUrl: config.baseUrl || defaultConfig.baseUrl,
      remoteUrl: config.remoteUrl || defaultConfig.remoteUrl,
      useRemote: config.useRemote !== undefined ? config.useRemote : defaultConfig.useRemote,
      model: config.model || defaultConfig.model,
      temperature: config.temperature || defaultConfig.temperature,
      maxTokens: config.maxTokens || defaultConfig.maxTokens,
    };
    
    // Try remote first if enabled and configured
    const urlToUse = (this.config.useRemote && this.config.remoteUrl) ? this.config.remoteUrl : this.config.baseUrl;
    
    this.client = new LMStudioClient({
      baseUrl: urlToUse,
    });
  }

  async connect(): Promise<void> {
    try {
      // LMStudioClient doesn't need explicit connect
      const models = await this.client.model.list();
      
      // Find preferred model or use first available
      const preferredModel = models.find(m => m.id.includes(this.config.model!));
      this.model = preferredModel || models[0];
      
      if (!this.model) {
        throw new Error('No models available in LM Studio');
      }
      
      this.emit('connected', this.model.id);
    } catch (error) {
      // If remote fails and we were trying it, fallback to local
      if (this.config.useRemote && this.config.remoteUrl && this.client.baseUrl !== this.config.baseUrl) {
        console.log('Remote endpoint failed, falling back to local LM Studio...');
        this.client = new LMStudioClient({
          baseUrl: this.config.baseUrl,
        });
        
        try {
          const models = await this.client.model.list();
          const preferredModel = models.find(m => m.id.includes(this.config.model!));
          this.model = preferredModel || models[0];
          
          if (!this.model) {
            throw new Error('No models available in local LM Studio');
          }
          
          this.emit('connected', this.model.id + ' (local fallback)');
          return;
        } catch (fallbackError) {
          this.emit('error', fallbackError);
          throw fallbackError;
        }
      }
      
      this.emit('error', error);
      throw error;
    }
  }

  async getCompletion(prompt: string, context?: string): Promise<string> {
    if (!this.model) {
      throw new Error('Not connected to LM Studio');
    }

    const messages: ChatMessage[] = [];
    
    if (context) {
      messages.push({
        role: 'system',
        content: `You are an intelligent terminal assistant. Help with command line tasks. Context: ${context}`,
      });
    }
    
    messages.push({
      role: 'user',
      content: prompt,
    });

    try {
      const response = await this.model.chat(messages, {
        temperature: this.config.temperature,
        maxTokens: this.config.maxTokens,
      });

      return response.content;
    } catch (error) {
      this.emit('error', error);
      throw error;
    }
  }

  async getStreamingCompletion(
    prompt: string,
    onToken: (token: string) => void,
    context?: string
  ): Promise<void> {
    if (!this.model) {
      throw new Error('Not connected to LM Studio');
    }

    const messages: ChatMessage[] = [];
    
    if (context) {
      messages.push({
        role: 'system',
        content: `You are an intelligent terminal assistant. Context: ${context}`,
      });
    }
    
    messages.push({
      role: 'user',
      content: prompt,
    });

    const stream = this.model.chatStream(messages, {
      temperature: this.config.temperature,
      maxTokens: this.config.maxTokens,
    });

    for await (const chunk of stream) {
      onToken(chunk.content);
    }
  }

  disconnect(): void {
    this.client.disconnect();
    this.emit('disconnected');
  }
}